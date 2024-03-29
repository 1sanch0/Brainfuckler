program BrainfuckCompiler;

uses
  sysutils,
  process;

function TranspileToC(inputName: string): AnsiString;

const
  tapeSize: integer = 1 << 13;

var
  c: Char;
  inputFile: File of char;

  output: AnsiString = '';

begin
  Assign(inputFile, inputName);
  Reset(inputFile);
   
  // TODO: check if opened correctly

  while not Eof(inputFile) do
  begin
    read(inputFile, c);
    case c of 
      '>': output := output + 'ptr++;' + LineEnding;
      '<': output := output + 'ptr--;' + LineEnding;
      '+': output := output + '(*ptr)++;' + LineEnding;
      '-': output := output + '(*ptr)--;' + LineEnding;
      '.': output := output + 'putchar(*ptr);' + LineEnding;
      ',': output := output + '(*ptr) = getchar();' + LineEnding;
      '[': output := output + 'while(*ptr) {' + LineEnding;
      ']': output := output + '}' + LineEnding;
    end;
  end;

  TranspileToC := '// C Source generated by brainfuckler,' + LineEnding;
  TranspileToC := TranspileToC + '// a Brainfuck compiler written in Free Pascal' + LineEnding;
  TranspileToC := TranspileToC + '#include <stdio.h>' + LineEnding + LineEnding;
  TranspileToC := TranspileToC + 'int main() {' + LineEnding;
  TranspileToC := TranspileToC + 'char tape[' + IntToStr(tapeSize) + '] = {0};' + LineEnding;
  TranspileToC := TranspileToC + 'char *ptr = tape;' + LineEnding + LineEnding;
  TranspileToC := TranspileToC + output + LineEnding;
  TranspileToC := TranspileToC + '}';

  close(inputFile);
end;

procedure Compile(cSource: AnsiString; outputName: string);

const
  processOptions: TProcessOptions = [poWaitOnExit, poStderrToOutPut];

var
  tmpFileName: string;
  tmpFile: TextFile;

  cmdOutput: AnsiString;
  success: Boolean;

begin
  tmpFileName := GetTempFileName;

  // TODO: check if open and whatnot

  Assign(tmpFile, tmpFileName);
  Rewrite(tmpFile);
  writeln(tmpFile, cSource);
  close(tmpFile);

  writeLn('Temporary file with c source created: ', tmpFileName);
  
  success := RunCommand('gcc', ['-x', 'c', tmpFileName, '-o', outputName], cmdOutput, processOptions);

  if success then
    writeln('Compilation was successful. ' + outputName + ' created!')
  else
    writeln('Compilation failed: ', cmdOutput);

end;


var
  inputName: string;
  outputName: string = 'a.out';

  cSource: AnsiString;

begin
  if (paramCount() = 0) then
  begin
    writeLn('Error: no input file');
    Halt (1);
  end;

  inputName := paramStr(1);
  if (paramCount() > 1) then
    outputName := paramStr(2);

  cSource := TranspileToC(inputName);
  
  Compile(cSource, outputName);
end.
