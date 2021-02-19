// Based on https://qiita.com/shirosuke_93/items/d5d068bb15c8e8817c34
#include <string>
#include <fstream>
#include <sstream>
#include <vector>
#include <iostream>

int main (int argc, char* argv[]) {
  const unsigned int dim = std::atoi(argv[1]);
  const bool isvector = std::atoi(argv[2])>0;
  const std::string input_csv_file_path  = argv[3];
  const std::string output_csv_file_path = argv[4];
  std::vector<std::ofstream> csv_writer;
  std::string header = "time, ";
  unsigned int value_dim;
  int maxtimestep = -1;
  int num_data = 1;

  std::ios::sync_with_stdio(false);

  if(dim==2){
    header += "x coord 0, y coord 0, z coord 0, x coord 1, y coord 1, z coord 1, x coord 2, y coord 2, z coord 2, ";
    num_data += 9;
  }
  else if(dim==3){
    header += "x coord 0, y coord 0, z coord 0, x coord 1, y coord 1, z coord 1, x coord 2, y coord 2, z coord 2, x coord 3, y coord 3, z coord 3, ";
    num_data += 12;
  }
  else{
      std::cout<<"dim Error"<<std::endl;
      exit(1);
  }
  if(isvector){
      header += "x scalar, y scalar, z scalar";
      value_dim = 3;
      num_data += 3;
  }
  else{
      header += "scalar";
      value_dim = 1;
      num_data += 3;
  }
  // 読み込むcsvファイルを開く(std::ifstreamのコンストラクタで開く)
  std::ifstream ifs_csv_file(input_csv_file_path);

  // getline関数で1行ずつ読み込む(読み込んだ内容はstr_bufに格納)
  std::string str_buf;
  while (std::getline(ifs_csv_file, str_buf)) {
    // 「,」区切りごとにデータを読み込むためにistringstream型にする
    std::istringstream i_stream(str_buf);

    std::string current_time,str_conma_buf;
    std::getline(i_stream, current_time, ' ');
    int current_time_int = std::stoi(current_time);
    if(current_time_int>maxtimestep){
        // 書き込むcsvファイルを開く(std::ofstreamのコンストラクタで開く)
        csv_writer.emplace_back(std::ofstream{output_csv_file_path+"."+current_time});
        csv_writer[current_time_int]<<header<<std::endl;
        maxtimestep=current_time_int;
    }

    unsigned int num_written = 0;
    // space 区切りごとにデータを読み込む
    while (std::getline(i_stream, str_conma_buf, ' ')) {
       // csvファイルに書き込む
       if(str_conma_buf.empty()) continue;
       csv_writer[current_time_int] << str_conma_buf;
       num_written += 1;
       if(num_written<num_data) csv_writer[current_time_int] << ',';
       else break;
    }
    // 改行する
    csv_writer[current_time_int] << std::endl;
  }

  // クローズ処理は不要[理由]ifstream型・ofstream型ともにデストラクタにてファイルクローズしてくれるため
}